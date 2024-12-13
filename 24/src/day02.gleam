import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input02.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(" ") |> list.filter_map(fn(x) { int.parse(x) })
  })
}

fn check(line: List(Int)) {
  {
    is_sorted(line, by: int.compare)
    || is_sorted(line, by: int.compare |> order.reverse)
  }
  && line
  |> list.window_by_2
  |> list.all(fn(x) {
    let diff = int.absolute_value(x.0 - x.1)
    1 <= diff && diff <= 3
  })
}

pub fn part1(input: String) {
  let input = parse(input)
  input
  |> list.filter(check)
  |> list.length
}

pub fn part2(input: String) {
  let input = parse(input)
  input
  |> list.filter(fn(line) {
    let len = line |> list.length
    list.range(0, len - 1)
    |> list.filter_map(fn(index) {
      let candidate = remove_at(line, index)
      case check(candidate) {
        True -> Ok(candidate)
        False -> Error(Nil)
      }
    })
    |> fn(x) { !list.is_empty(x) }
  })
  |> list.length
}

fn remove_at(list: List(a), index: Int) {
  case list {
    [] -> []
    [item, ..rest] ->
      case index == 0 {
        True -> rest
        False -> [item, ..remove_at(rest, index - 1)]
      }
  }
}

fn is_sorted(list: List(a), by get_order: fn(a, a) -> order.Order) -> Bool {
  case list {
    [] -> True
    [_] -> True
    [head, next, ..rest] ->
      get_order(head, next) == order.Gt
      && is_sorted([next, ..rest], by: get_order)
  }
}
