import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result.{try}
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input05.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  let assert Ok(#(rules, updates)) =
    input |> string.trim |> string.split_once("\n\n")
  let map =
    rules
    |> string.split("\n")
    |> list.filter_map(string.split_once(_, "|"))
    |> list.filter_map(fn(rule) {
      let #(l, r) = rule
      use l <- try(int.parse(l))
      use r <- try(int.parse(r))
      Ok(#(l, r))
    })
    |> list.fold(dict.new(), fn(acc, rule) {
      let #(l, r) = rule
      dict.upsert(acc, l, fn(x) {
        case x {
          Some(s) -> set.insert(s, r)
          None -> set.from_list([r])
        }
      })
    })
  let updates =
    updates
    |> string.split("\n")
    |> list.map(fn(update) {
      update |> string.split(",") |> list.filter_map(int.parse)
    })
  #(map, updates)
}

fn possible_p1(map: Dict(Int, Set(Int)), used: set.Set(Int), update: List(Int)) {
  case update {
    [] -> True
    [a, ..rest] -> {
      let intersection =
        set.intersection(result.unwrap(dict.get(map, a), set.new()), used)
      case set.size(intersection) {
        0 -> possible_p1(map, set.insert(used, a), rest)
        _ -> False
      }
    }
  }
}

fn dfs(
  map: Dict(Int, Set(Int)),
  ignore_except: Set(Int),
  vis: Set(Int),
  cursearch: Set(Int),
  v: Int,
) -> Result(#(List(Int), Set(Int), Set(Int)), Nil) {
  case set.contains(vis, v) || !set.contains(ignore_except, v) {
    True -> Ok(#([], vis, cursearch))
    False -> {
      let vis = set.insert(vis, v)
      let cursearch = set.insert(cursearch, v)
      use #(res, vis, cursearch) <- try(
        dict.get(map, v)
        |> result.unwrap(set.new())
        |> set.fold(Ok(#([], vis, cursearch)), fn(acc, w) {
          use #(res, vis, cursearch) <- try(acc)
          case set.contains(cursearch, w) {
            True -> Error(Nil)
            False -> {
              use #(cur_res, vis, cursearch) <- try(dfs(
                map,
                ignore_except,
                vis,
                cursearch,
                w,
              ))
              Ok(#(list.append(cur_res, res), vis, cursearch))
            }
          }
        }),
      )
      let cursearch = set.delete(cursearch, v)
      Ok(#([v, ..res], vis, cursearch))
    }
  }
}

fn reverse(map: Dict(a, Set(a))) {
  map
  |> dict.to_list()
  |> list.fold(dict.new(), fn(acc, entry) {
    let #(from, to) = entry
    let reversed_from =
      set.to_list(to)
      |> list.fold(dict.new(), fn(acc, to) {
        dict.upsert(acc, to, fn(x) {
          case x {
            Some(s) -> set.insert(s, from)
            None -> set.from_list([from])
          }
        })
      })
    dict.combine(acc, reversed_from, set.union)
  })
}

fn toposort(map: Dict(Int, Set(Int)), ignore_except: Set(Int)) {
  map
  |> dict.keys
  |> list.fold(#([], set.new()), fn(acc, v) {
    let #(res, vis) = acc
    // WHY ARE THERE CYCLES IN THE COMPLETE RULESET? (e.g. 21->19->13->11->39->21)
    let assert Ok(#(cur_res, vis, _)) =
      dfs(map, ignore_except, vis, set.new(), v)
    let cur_res = cur_res |> list.reverse
    #(list.append(res, cur_res), vis)
  })
  |> pair.first
}

fn middle(a: List(a)) {
  let len = list.length(a)
  let half = len / 2
  list.first(list.drop(a, half))
}

pub fn part1(input: String) {
  let #(map, updates) = parse(input)
  updates
  |> list.fold(0, fn(acc, update) {
    case possible_p1(map, set.new(), update) {
      True -> acc + result.unwrap(middle(update), 0)
      False -> acc
    }
  })
}

pub fn part2(input: String) {
  let #(map, updates) = parse(input)
  let reversed = reverse(map)
  updates
  |> list.fold(0, fn(acc, update) {
    case possible_p1(map, set.new(), update) {
      True -> acc
      False -> {
        let toposort = toposort(reversed, set.from_list(update))
        acc
        + result.unwrap(
          toposort |> list.filter(list.contains(update, _)) |> middle,
          0,
        )
      }
    }
  })
}
