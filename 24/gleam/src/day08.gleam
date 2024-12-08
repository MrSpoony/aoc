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
  let assert Ok(input) = simplifile.read("inputs/input08.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  let input =
    input |> string.trim |> string.split("\n") |> list.map(string.to_graphemes)
  let height = input |> list.length
  let width = input |> list.first |> result.unwrap([]) |> list.length
  let map: Dict(String, Set(#(Int, Int))) =
    input
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      line
      |> list.index_fold(acc, fn(acc, char, j) {
        case char {
          "." -> acc
          _ ->
            dict.upsert(acc, char, fn(x) {
              case x {
                None -> set.from_list([#(i, j)])
                Some(s) -> set.insert(s, #(i, j))
              }
            })
        }
      })
    })
  #(height, width, map)
}

fn get_second(first: a, rest: List(a)) {
  case rest {
    [] -> []
    [head, ..rest] ->
      case head == first {
        True -> get_second(first, rest)
        False -> [#(first, head), ..get_second(first, rest)]
      }
  }
}

fn get_pairs(nums: List(a)) {
  case nums {
    [] -> []
    [head, ..rest] -> [get_second(head, rest), ..get_pairs(rest)]
  }
}

pub fn part1(input: String) {
  let #(height, width, map) = parse(input)
  dict.values(map)
  |> list.flat_map(fn(x) {
    let pairs = get_pairs(x |> set.to_list) |> list.flatten
    pairs
    |> list.flat_map(fn(pair) {
      let #(a, b) = pair
      let #(ax, ay) = a
      let #(bx, by) = b
      let dx = ax - bx
      let dy = ay - by
      let new_a = #(ax + dx, ay + dy)
      let new_b = #(bx - dx, by - dy)
      [new_a, new_b]
    })
  })
  |> list.filter(fn(pos) {
    let #(x, y) = pos
    x >= 0 && x < height && y >= 0 && y < width
  })
  |> list.unique
  |> list.length
}

pub fn part2(input: String) {
  let #(height, width, map) = parse(input)
  dict.values(map)
  |> list.flat_map(fn(x) {
    let pairs = get_pairs(x |> set.to_list) |> list.flatten
    pairs
    |> list.flat_map(fn(pair) {
      let #(a, b) = pair
      let #(ax, ay) = a
      let #(bx, by) = b
      let dx = ax - bx
      let dy = ay - by
      let mindim = int.min(height, width)
      list.range(-mindim, mindim)
      |> list.flat_map(fn(i) {
        let new_a = #(ax + dx * i, ay + dy * i)
        let new_b = #(bx - dx * i, by - dy * i)
        [new_a, new_b]
      })
    })
  })
  |> list.filter(fn(pos) {
    let #(x, y) = pos
    x >= 0 && x < height && y >= 0 && y < width
  })
  |> list.unique
  |> list.length
}
