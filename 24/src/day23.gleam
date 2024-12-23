import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input23.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> io.println
}

fn parse(input: String) {
  let update = fn(a, b) {
    case a {
      None -> set.from_list([b])
      Some(bs) -> bs |> set.insert(b)
    }
  }
  input
  |> string.trim
  |> string.split("\n")
  |> list.fold(dict.new(), fn(acc, line) {
    let assert Ok(#(from, to)) = line |> string.split_once("-")
    acc |> dict.upsert(from, update(_, to)) |> dict.upsert(to, update(_, from))
  })
}

fn get_c(g: Dict(String, Set(String)), v: String) {
  g |> dict.get(v) |> result.unwrap([] |> set.from_list)
}

// https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm
fn bron_kerbosch(
  g: Dict(String, Set(String)),
  r: Set(String),
  p: Set(String),
  x: Set(String),
) -> Set(String) {
  use <- bool.guard(p |> set.is_empty && x |> set.is_empty, r)
  let assert Ok(pivot) = p |> set.union(x) |> set.to_list |> list.first
  let #(_, _, res) =
    p
    |> set.drop(g |> get_c(pivot) |> set.to_list)
    |> set.to_list
    |> list.fold(#(p, x, set.new()), fn(acc, v) {
      let #(p, x, best) = acc
      let v_c = g |> get_c(v)
      let other_best =
        bron_kerbosch(
          g,
          r |> set.union(set.from_list([v])),
          p |> set.intersection(v_c),
          x |> set.intersection(v_c),
        )
      let p = p |> set.delete(v)
      let x = x |> set.union(set.from_list([v]))
      let best = case other_best |> set.size > best |> set.size {
        True -> other_best
        False -> best
      }
      #(p, x, best)
    })
  res
}

pub fn part1(input: String) {
  let g = parse(input)
  g
  |> dict.fold([], fn(acc, a, a_c) {
    a_c
    |> set.fold(acc, fn(acc, b) {
      g
      |> get_c(b)
      |> set.fold(acc, fn(acc, c) {
        case g |> get_c(c) |> set.contains(a) {
          True -> [[a, b, c], ..acc]
          False -> acc
        }
      })
    })
  })
  |> list.map(list.sort(_, string.compare))
  |> list.unique
  |> list.filter(fn(l) { l |> list.any(fn(s) { s |> string.starts_with("t") }) })
  |> list.length
}

pub fn part2(input: String) {
  let g = parse(input)
  bron_kerbosch(g, set.new(), g |> dict.keys |> set.from_list, set.new())
  |> set.to_list
  |> list.sort(string.compare)
  |> string.join(",")
}
