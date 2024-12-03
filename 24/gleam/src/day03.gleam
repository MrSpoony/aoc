import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input03.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn get_digit(char: String) {
  case char {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    c -> Error(c)
  }
}

pub fn parse_number(
  input: List(String),
  length: Int,
  first first_num: Bool,
) -> Result(#(Int, Int, List(String)), List(String)) {
  case input {
    [] -> Error([""])
    [first] -> {
      use digit <- result.try(result.map_error(get_digit(first), fn(e) { [e] }))
      Ok(#(digit, 1, [""]))
    }
    [first, ..rest] -> {
      use digit <- result.try(
        result.map_error(get_digit(first), fn(e) { [e, ..rest] }),
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
            [",", ..rest] ->
              case first_num {
                True -> Ok(#(digit, 1, rest))
                False -> Error(c)
              }
            [")", ..rest] ->
              case first_num {
                True -> Error(c)
                False -> Ok(#(digit, 1, rest))
              }
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
      let num = parse_number(rest, 1, first: True)
      case num {
        Ok(#(num, _, rest)) -> {
          let num2 = parse_number(rest, 1, first: False)
          case num2 {
            Ok(#(num2, _, rest)) -> {
              num * num2 + find_muls_part1(rest)
            }
            Error(rest) -> find_muls_part1(rest)
          }
        }
        Error(rest) -> find_muls_part1(rest)
      }
    }
    [_, ..rest] -> find_muls_part1(rest)
    [] -> 0
  }
}

fn find_muls_part2(input: List(String), do: Bool) {
  case do {
    True ->
      case input {
        ["m", "u", "l", "(", ..rest] -> {
          let num = parse_number(rest, 1, first: True)
          case num {
            Ok(#(num, _, rest)) -> {
              let num2 = parse_number(rest, 1, first: False)
              case num2 {
                Ok(#(num2, _, rest)) -> {
                  num * num2 + find_muls_part2(rest, do)
                }
                Error(rest) -> find_muls_part2(rest, do)
              }
            }
            Error(rest) -> find_muls_part2(rest, do)
          }
        }
        ["d", "o", "n", "'", "t", "(", ")", ..rest] ->
          find_muls_part2(rest, False)
        [_, ..rest] -> find_muls_part2(rest, do)
        [] -> 0
      }
    False ->
      case input {
        ["d", "o", "(", ")", ..rest] -> find_muls_part2(rest, True)
        [_, ..rest] -> find_muls_part2(rest, do)
        [] -> 0
      }
  }
}

pub fn part1(input: String) {
  find_muls_part1(string.to_graphemes(input))
}

pub fn part2(input: String) {
  find_muls_part2(string.to_graphemes(input), True)
}
