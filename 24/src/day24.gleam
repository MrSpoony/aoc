import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input24.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> io.println
}

type Op {
  AND
  OR
  XOR
}

fn parse_op(s: String) {
  case s {
    "AND" -> AND
    "OR" -> OR
    "XOR" -> XOR
    _ -> panic as "invalid op"
  }
}

type Number {
  Literal(Bool)
  Computed(a: Number, b: Number, op: Op)
  Ref(String)
}

fn parse(input: String) {
  let assert Ok(#(literals, computed)) =
    input |> string.trim |> string.split_once("\n\n")
  let nums =
    literals
    |> string.split("\n")
    |> list.fold(dict.new(), fn(acc, line) {
      let assert Ok(#(name, val)) = line |> string.split_once(": ")
      let assert Ok(val) = int.parse(val)
      let val = val == 1
      acc |> dict.insert(name, Literal(val))
    })
  computed
  |> string.split("\n")
  |> list.fold(nums, fn(acc, line) {
    let parts = line |> string.split(" ")
    let assert Ok(a) = parts |> list.first
    let assert Ok(op) = parts |> list.drop(1) |> list.first
    let assert Ok(b) = parts |> list.drop(2) |> list.first
    let assert Ok(res) = parts |> list.drop(4) |> list.first
    acc |> dict.insert(res, Computed(Ref(a), Ref(b), parse_op(op)))
  })
}

fn compute(map: Dict(String, Number), key: Number) {
  case key {
    Literal(x) -> x
    Ref(s) -> {
      let assert Ok(s) = map |> dict.get(s)
      compute(map, s)
    }
    Computed(a, b, op) -> {
      let a = compute(map, a)
      let b = compute(map, b)
      case op {
        OR -> bool.or(a, b)
        AND -> bool.and(a, b)
        XOR -> bool.exclusive_or(a, b)
      }
    }
  }
}

pub fn part1(input: String) {
  let map = parse(input)
  map
  |> dict.keys
  |> list.filter(fn(x) { x |> string.starts_with("z") })
  |> list.map(fn(key) {
    let assert Ok(v) = map |> dict.get(key)
    #(key, compute(map, v))
  })
  |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
  |> list.reverse
  |> list.map(pair.second)
  |> list.fold(0, fn(acc, x) { acc * 2 + bool.to_int(x) })
}

pub fn part2(input: String) {
  let map = parse(input)
  let str = fn(x) {
    case x {
      OR -> "or"
      AND -> "and"
      XOR -> "xor"
    }
  }
  let flips = [
    #("z05", "frn"),
    #("gmq", "z21"),
    #("wtt", "z39"),
    #("wnf", "vtj"),
  ]
  let flip_map =
    flips
    |> list.append(flips |> list.map(fn(p) { #(p.1, p.0) }))
    |> dict.from_list
  map
  |> dict.map_values(fn(k, v) {
    case v {
      Computed(a, b, op) -> {
        let flip = fn(x) { flip_map |> dict.get(x) |> result.unwrap(x) }
        let assert Ref(a) = a
        let assert Ref(b) = b
        flip(k)
        <> " -> "
        <> flip(a)
        <> " [label="
        <> str(op)
        <> "];\n"
        <> flip(k)
        <> " -> "
        <> flip(b)
        <> " [label="
        <> str(op)
        <> "];\n"
      }
      _ -> ""
    }
  })
  |> dict.values
  |> string.join("")
  // |> io.println // analyze graphviz output manually

  flip_map |> dict.keys |> list.sort(string.compare) |> string.join(",")
}
