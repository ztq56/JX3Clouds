defmodule Model do
  defmodule Repo do
    use Ecto.Repo, otp_app: :jx3replay

    defmodule LogEntry do
      def log(%{query: query} = entry) do
        cond do
          query =~ ~r/^SELECT .* FROM "(items|matches)" AS .*/ -> entry
          true -> Ecto.LogEntry.log(entry)
        end
      end
    end
  end

  defmodule AnyType do
    def type, do: :jsonb
    def load(i), do: {:ok, i}
    def cast(i), do: {:ok, i}
    def dump(i), do: {:ok, i}
  end

  defmodule DateRangeType do
    @behaviour Ecto.Type
    def type, do: :daterange
    def load(%Postgrex.Range{} = range), do: apply_range(range, &Ecto.Date.load/1)
    def load(_), do: :error
    def cast([lower, upper], opts) do
      lower_inclusive = case opts[:upper_inclusive] do
        nil -> true
        x -> x
      end
      upper_inclusive = opts[:upper_inclusive] || false
      cast(%Postgrex.Range{lower: lower, lower_inclusive: lower_inclusive, upper: upper, upper_inclusive: upper_inclusive})
    end
    def cast(%Postgrex.Range{} = range), do: apply_range(range, &Ecto.Date.cast/1)
    def cast([lower, upper]), do: cast([lower, upper], [])
    def cast(_), do: :error
    def dump(%Postgrex.Range{} = range), do: apply_range(range, &Ecto.Date.dump/1)
    def dump(_), do: :error
    def apply_range(%Postgrex.Range{lower: lower, upper: upper} = range, func) do
      func = fn nil -> {:ok, nil}; x -> func.(x) end
      case {func.(lower), func.(upper)} do
        {{:ok, lower}, {:ok, upper}} -> {:ok, %{range | lower: lower, upper: upper}}
        _ -> :error
      end
    end

    def in?(%Postgrex.Range{} = r, %Ecto.Date{} = i) do
      {:ok, r} = cast(r)
      cond do
        r.lower != nil and Ecto.Date.compare(i, r.lower) == :lt -> false
        r.lower != nil and r.lower_inclusive == false and Ecto.Date.compare(i, r.lower) == :eq -> false
        r.upper != nil and r.upper_inclusive != true and Ecto.Date.compare(i, r.upper) == :eq -> false
        r.upper != nil and Ecto.Date.compare(i, r.upper) == :eq -> false
        true -> true
      end
    end

    def compare(true, false), do: :gt
    def compare(false, true), do: :lt
    def compare(x, y) when is_boolean(x) and is_boolean(y) and x == y, do: :eq
    def compare(r1, r2) do
      r = [
        Ecto.Date.compare(r1.lower, r2.lower),
        compare(r2.lower_inclusive, r1.lower_inclusive),
        Ecto.Date.compare(r1.upper, r2.upper),
        compare(r2.upper_inclusive, r1.upper_inclusive),
      ] |> Enum.filter(&:eq != &1)
      case r do
        [i | _] -> i
        [] -> :eq
      end
    end
  end

  defmodule Item do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "items" do
      field :tag, :string, primary_key: true
      field :id, :string, primary_key: true
      field :content, AnyType
      timestamps()
    end

    @permitted ~w(content)a

    def changeset(item, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(item, change, @permitted)
    end
  end

  defmodule Person do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key {:person_id, :string, autogenerate: false}
    schema "persons" do
      # globalId, passportId, personId
      # personInfo: { bodyType, force, gameGlobalRoleId, gameRoleId, miniAvatar, passportId, person: {avatarUrl, id, nickName, signature}, roleName, server, zone }
      # rankNum, score, upNum, winRate
      field :name, :string
      field :avatar, :string
      field :signature, :string
      has_many :roles, Model.Role, foreign_key: :person_id
      timestamps()

      @permitted ~w(name avatar signature)a

      def changeset(person, change \\ :empty) do
        change = change
        |> Enum.filter(fn {_, v} -> v != nil end)
        |> Enum.into(%{})
        cast(person, change, @permitted)
      end
    end
  end

  defmodule Role do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key {:global_id, :string, autogenerate: false}
    schema "roles" do
      field :role_id, :id
      field :passport_id, :string
      field :name, :string
      field :force, :string
      field :body_type, :string
      field :camp, :string
      field :zone, :string
      field :server, :string
      belongs_to :person, Person, type: :string, references: :person_id
      has_many :performances, Model.RolePerformance, foreign_key: :role_id
      timestamps()

      @permitted ~w(role_id passport_id name force body_type camp zone server person_id)a

      def changeset(role, change \\ :empty) do
        change = change
        |> Enum.filter(fn {_, v} -> v != nil end)
        |> Enum.into(%{})
        cast(role, change, @permitted)
      end
    end
  end

  defmodule RoleLog do
    use Ecto.Schema
    import Ecto.Changeset
    schema "role_logs" do
      belongs_to :role, Role, type: :string, references: :global_id, foreign_key: :global_id
      field :role_id, :id, default: 0
      field :name, :string, default: ""
      field :zone, :string, default: ""
      field :server, :string, default: ""
      field :passport_id, :string, default: ""
      field :seen, {:array, DateRangeType}
      timestamps()
    end

    @permitted ~w(role_id global_id name zone server passport_id seen)a

    def diff_date(%Ecto.Date{} = d1, %Ecto.Date{} = d2) do
      {:ok, d1} = d1 |> Ecto.Date.to_erl |> Date.from_erl
      {:ok, d2} = d2 |> Ecto.Date.to_erl |> Date.from_erl
      diff_date(d1, d2)
    end
    def diff_date(%Date{} = d1, %Date{} = d2) do
      Date.diff(d1, d2)
    end
    def diff_date(d1, d2) do
      {:ok, d1} = Ecto.Date.cast(d1)
      {:ok, d2} = Ecto.Date.cast(d2)
      diff_date(d1, d2)
    end

    def insert_seen(nil, [], acc) do
      Enum.reverse(acc)
    end
    def insert_seen(a, [], acc) do
      a = case a do
        {s, nil, nil} -> DateRangeType.cast([s, s], upper_inclusive: true)
        {_, l, nil} -> {:ok, l}
        {_, nil, r} -> {:ok, r}
        _ -> :error
      end
      case a do
        {:ok, day} -> [day | acc]
        _ -> insert_seen(nil, [], acc)
      end |> Enum.sort(fn i, j -> DateRangeType.compare(i, j) in [:lt, :eq] end)
    end
    def insert_seen(nil, [h | t], acc) do
      insert_seen(nil, t, [h | acc])
    end
    def insert_seen({nil, nil, nil}, t, acc) do
      insert_seen(nil, t, acc)
    end
    def insert_seen({s, l, r}, [h | t], acc) do
      {s, l, r, h} = cond do
        l == nil and r == nil and DateRangeType.in?(h, s) -> {nil, l, r, h}
        r == nil and h.lower_inclusive == false and s == h.lower -> {s, l, %{h | lower_inclusive: true}, nil}
        r == nil and h.lower_inclusive == true and diff_date(s, h.lower) == -1 -> {s, l, %{h | lower: s, lower_inclusive: true}, nil}
        l == nil and h.upper_inclusive == false and s == h.upper -> {s, %{h | upper_inclusive: true}, r, nil}
        l == nil and h.upper_inclusive == true and diff_date(s, h.upper) == 1 -> {s, %{h | upper: s, upper_inclusive: true}, r, nil}
        true -> {s, l, r, h}
      end
      if l != nil and r != nil do
        acc = [%{l | upper: r.upper, upper_inclusive: r.upper_inclusive} | acc]
        insert_seen(nil, t, h && [h | acc] || acc)
      else
        insert_seen({s, l, r}, t, h && [h | acc] || acc)
      end
    end

    def insert_seen(seen, a) do
      a = a || []
      case Ecto.Date.cast(seen) do
        {:ok, s} ->
          cond do
            Enum.any?(a, &DateRangeType.in?(&1, s)) -> a
            true -> insert_seen({s, nil, nil}, a, [])
          end
        _ -> a
      end
    end

    def changeset(role, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      |> Map.put(:seen, insert_seen(change[:seen], role.seen))
      case role do
        %RoleLog{} -> cast(role, change, @permitted)
        _ -> cast(role, change, [:seen])
      end
    end
  end

  defmodule RolePerformance do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "scores" do
      belongs_to :role, Role, type: :string, references: :global_id, primary_key: true
      field :pvp_type, :integer, primary_key: true
      field :score, :integer
      field :score2, :integer
      field :grade, :integer
      field :ranking, :integer
      field :ranking2, :integer
      field :total_count, :integer
      field :win_count, :integer
      field :mvp_count, :integer
      field :fetch_at, :naive_datetime

      timestamps()
    end

    @permitted ~w(score score2 grade ranking ranking2 total_count win_count mvp_count fetch_at)a

    def fix_pvptype(%{pvp_type: t} = change) do
      pvp_type = cond do
        is_integer(t) -> t
        is_binary(t) and Integer.parse(t) != :error -> {x, _} = Integer.parse(t); x
        true -> 0
      end
      %{change | pvp_type: pvp_type}
    end
    def fix_pvptype(change), do: change

    def fix_ranking(%{ranking: r} = change) do
      ranking = cond do
        is_integer(r) -> r
        String.at(r, -1) == "%" -> r |> String.trim_trailing("%") |> String.to_integer |> Kernel.-
        true -> r |> String.to_integer
      end
      %{change | ranking: ranking}
    end
    def fix_ranking(change), do: change

    def changeset(perf, change \\ :empty) do
      change = change |> fix_pvptype |> fix_ranking
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(perf, change, @permitted)
    end
  end

  defmodule RolePerformanceLog do
    use Ecto.Schema
    import Ecto.Changeset
    schema "score_logs" do
      field :pvp_type, :integer
      field :score, :integer
      field :grade, :integer
      field :ranking, :integer
      field :total_count, :integer
      field :win_count, :integer
      field :mvp_count, :integer
      belongs_to :role, Role, type: :string, references: :global_id

      timestamps(updated_at: false)
    end

    @permitted ~w(pvp_type score grade ranking total_count win_count mvp_count role_id)a

    def changeset(perf, change \\ :empty) do
      change = change |> RolePerformance.fix_pvptype |> RolePerformance.fix_ranking
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(perf, change, @permitted)
    end
  end

  defmodule Match do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key {:match_id, :integer, autogenerate: false}
    schema "matches" do
      field :start_time, :integer
      field :duration, :integer
      field :pvp_type, :integer
      field :map, :integer
      field :grade, :integer
      field :total_score1, :integer
      field :total_score2, :integer
      field :team1, {:array, :integer}
      field :team2, {:array, :integer}
      field :winner, :integer
      has_many :roles, Model.MatchRole, foreign_key: :match_id

      timestamps(updated_at: false)
    end

    @permitted ~w(start_time duration pvp_type map grade total_score1 total_score2 team1 team2 winner)a

    def changeset(match, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(match, change, @permitted)
    end
  end

  defmodule MatchRole do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key false
    schema "match_roles" do
      belongs_to :match, Match, references: :match_id, primary_key: true
      belongs_to :role, Role, type: :string, references: :global_id, primary_key: true
      field :kungfu, :integer
      field :score, :integer
      field :score2, :integer
      field :ranking, :integer
      field :equip_score, :integer
      field :equip_addition_score, :integer
      field :max_hp, :integer
      field :metrics_version, :integer
      field :metrics, {:array, :float}
      field :equips, {:array, :integer}
      field :talents, {:array, :integer}
      field :attrs_version, :integer
      field :attrs, {:array, :float}

      timestamps(updated_at: false)
    end

    @permitted ~w(kungfu score score2 ranking equip_score equip_addition_score max_hp
      metrics_version metrics equips talents attrs_version attrs)a

    def fix_attrs(%{attrs: attrs} = change) do
      attrs = attrs |> Enum.map(fn v -> {v, _} = Float.parse(v); v end)
      %{change | attrs: attrs}
    end
    def fix_attrs(change), do: change

    def changeset(role, change \\ :empty) do
      change = change |> RolePerformance.fix_pvptype |> RolePerformance.fix_ranking
      |> fix_attrs
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(role, change, @permitted)
    end
  end

  defmodule MatchLog do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key false
    schema "match_logs" do
      belongs_to :match, Match, references: :match_id, primary_key: true
      field :replay, :map

      timestamps(updated_at: false)
    end

    @permitted ~w(replay)a

    def changeset(log, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(log, change, @permitted)
    end
  end

  defmodule Query do
    import Ecto.Query

    def update_item(%{tag: tag, id: id} = item) do
      {tag, id} = {"#{tag}", "#{id}"}
      case Repo.get_by(Item, [tag: tag, id: id]) do
        nil -> %Item{tag: tag, id: id}
        item -> item
      end
      |> Item.changeset(item) |> Repo.insert_or_update
    end

    def get_items(tag \\ nil) do
      if tag do
        Repo.all(from i in Item, where: i.tag == ^tag)
      else
        Repo.all(from i in Item)
      end
      |> Enum.group_by(fn i -> i.tag end)
    end

    def update_person(%{person_id: id} = person) do
      p = case Repo.get(Person, id) do
        nil -> %Person{person_id: id}
        person -> person
      end
      p |> Person.changeset(person) |> Repo.insert_or_update
    end

    def update_role(%{global_id: id} = role) do
      r = case Repo.get(Role, id) do
        nil -> %Role{global_id: id}
        role -> role
      end
      r |> Role.changeset(role) |> Repo.insert_or_update
    end

    def insert_role_log(%{global_id: _} = role) do
      query = ~w(global_id name zone server passport_id)a
      |> Enum.map(&{&1, Map.get(role, &1) || ""})
      |> Keyword.put(:role_id, Map.get(role, :role_id) || 0)

      case Repo.get_by(RoleLog, query) do
        nil -> %RoleLog{}
        role -> role
      end |> RoleLog.changeset(role) |> Repo.insert_or_update
    end

    def get_role(id) do
      Repo.get(Role, id)
    end

    def get_roles do
      Repo.all(
        from(
          r in Role,
          left_join: s in RolePerformance,
          on: r.global_id == s.role_id,
          where: s.pvp_type == 3,
          order_by: [desc: s.score],
          select: {r, s}))
    end

    def update_performance(%{role_id: id, pvp_type: _} = perf) do
      %{pvp_type: pt} = RolePerformance.fix_pvptype(perf)
      p = case Repo.get_by(RolePerformance, [role_id: id, pvp_type: pt]) do
        nil -> %RolePerformance{role_id: id, pvp_type: pt}
        p -> p
      end
      |> RolePerformance.changeset(perf) |> Repo.insert_or_update

      if Map.has_key?(perf, :score) do
        %RolePerformanceLog{} |> RolePerformanceLog.changeset(perf) |> Repo.insert
      end
      p
    end

    def insert_match(%{match_id: id, roles: roles} = match) do
      case Repo.get(Match, id) do
        nil ->
          multi = Ecto.Multi.new
          |> Ecto.Multi.insert(:match, %Match{match_id: id} |> Match.changeset(match))
          {:ok, r} = Enum.reduce(roles, multi, fn r, multi ->
            role_id = Map.get(r, :global_id)
            multi |> Ecto.Multi.insert("role_#{role_id}", %MatchRole{match_id: id, role_id: role_id} |> MatchRole.changeset(r))
          end)
          |> Repo.transaction
          {:ok, %{Map.get(r, :match) | roles: Enum.map(roles, fn i ->
            role_id = Map.get(i, :global_id)
            Map.get(r, "role_#{role_id}")
          end)}}
        match -> match
      end
    end

    def get_match(id) do
      Repo.get(Match, id)
    end

    def get_matches do
      Repo.all(from m in Match, order_by: :match_id)
    end

    def get_matches_by_role(id) do
      Repo.all(from r in MatchRole, left_join: m in Match, on: r.match_id == m.match_id, where: r.role_id == ^id, order_by: m.start_time, select: m)
    end

    def insert_match_log(%{"match_id" => id} = log) do
      case Repo.get(MatchLog, id) do
        nil -> %MatchLog{match_id: id} |> MatchLog.changeset(%{replay: log}) |> Repo.insert_or_update
        log -> log
      end
    end
  end
end
