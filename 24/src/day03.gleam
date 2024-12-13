import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/result.{try}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input03.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

pub fn parse_number(
  input: List(String),
  length: Int,
  first first_num: Bool,
) -> Result(#(Int, Int, List(String)), List(String)) {
  case input {
    [] -> Error([""])
    [first] -> {
      first
      |> int.parse
      |> result.map_error(fn(_) { [first] })
      |> result.map(fn(digit) { #(digit, 1, [""]) })
    }
    [first, ..rest] -> {
      use digit <- try(
        first |> int.parse |> result.map_error(fn(_) { [first, ..rest] }),
      )
      case parse_number(rest, length + 1, first_num) {
        Ok(#(num, rest_length, rest)) -> {
          Ok(#(
            num
              + digit
              * float.round(result.unwrap(
              int.power(10, int.to_float(rest_length)),
              0.0,
            )),
            rest_length + 1,
            rest,
          ))
        }
        Error(c) -> {
          case c {
            [",", ..rest] if first_num -> Ok(#(digit, 1, rest))
            [")", ..rest] if !first_num -> Ok(#(digit, 1, rest))
            _ -> Error(c)
          }
        }
      }
    }
  }
}

fn find_muls_part1(input: List(String)) {
  case input {
    ["m", "u", "l", "(", ..rest] -> {
      case
        {
          use #(num, _, rest) <- try(parse_number(rest, 1, True))
          use #(num2, _, rest) <- try(parse_number(rest, 1, False))
          Ok(#(num * num2, rest))
        }
      {
        Ok(#(num, rest)) -> num + find_muls_part1(rest)
        Error(rest) -> find_muls_part1(rest)
      }
    }
    [_, ..rest] -> find_muls_part1(rest)
    [] -> 0
  }
}

fn find_muls_part2(input: List(String), do: Bool) {
  case input {
    ["m", "u", "l", "(", ..rest] -> {
      case
        {
          use #(num, _, rest) <- try(parse_number(rest, 1, True))
          use #(num2, _, rest) <- try(parse_number(rest, 1, False))
          Ok(#(num * num2, rest))
        }
      {
        Ok(#(num, rest)) -> bool.to_int(do) * num + find_muls_part2(rest, do)
        Error(rest) -> find_muls_part2(rest, do)
      }
    }
    ["d", "o", "n", "'", "t", "(", ")", ..rest] -> find_muls_part2(rest, False)
    ["d", "o", "(", ")", ..rest] -> find_muls_part2(rest, True)
    [_, ..rest] -> find_muls_part2(rest, do)
    [] -> 0
  }
}

pub fn part1(input: String) {
  find_muls_part1(string.to_graphemes(input))
}

pub fn part2(input: String) {
  find_muls_part2(string.to_graphemes(input), True)
}
