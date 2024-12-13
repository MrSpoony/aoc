import day03
import gleam/int
import gleam/list
import gleam/string
import gleeunit/should

pub fn parse_number_first_test() {
  list.range(100, 9999)
  |> list.map(fn(x) {
    let num = int.random(x)
    day03.parse_number(
      string.to_graphemes(int.to_string(num) <> ",x"),
      1,
      first: True,
    )
    |> should.equal(
      Ok(#(num, string.length(int.to_string(num)), string.to_graphemes("x"))),
    )
  })
}

pub fn parse_number_second_test() {
  list.range(100, 9999)
  |> list.map(fn(x) {
    let num = int.random(x)
    day03.parse_number(
      string.to_graphemes(int.to_string(num) <> ")lu"),
      1,
      first: False,
    )
    |> should.equal(
      Ok(#(num, string.length(int.to_string(num)), string.to_graphemes("lu"))),
    )
  })
}

pub fn parse_number_rest_test() {
  list.range(100, 9999)
  |> list.map(fn(x) {
    let num = int.random(x)
    day03.parse_number(
      string.to_graphemes(int.to_string(num) <> "blub"),
      1,
      first: False,
    )
    |> should.equal(Error(string.to_graphemes("blub")))
  })
}

const example_p1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const example_p2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part1_test() {
  day03.part1(example_p1)
  |> should.equal(161)
}

pub fn part2_test() {
  day03.part2(example_p2)
  |> should.equal(48)
}
