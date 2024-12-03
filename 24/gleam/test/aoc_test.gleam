import day01
import day02
import day03
import gleam/int
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn day01_test() {
  let example =
    "
3   4
4   3
2   5
1   3
3   9
3   3
"
  day01.part1(example)
  |> should.equal(11)
  day01.part2(example)
  |> should.equal(31)
}

pub fn day02_test() {
  let example =
    "
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"
  day02.part1(example)
  |> should.equal(2)

  day02.part2(example)
  |> should.equal(4)
}

pub fn day03_test() {
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
    day03.parse_number(
      string.to_graphemes(int.to_string(num) <> ")lu"),
      1,
      first: False,
    )
    |> should.equal(
      Ok(#(num, string.length(int.to_string(num)), string.to_graphemes("lu"))),
    )
    day03.parse_number(
      string.to_graphemes(int.to_string(num) <> "blub"),
      1,
      first: False,
    )
    |> should.equal(Error(string.to_graphemes("blub")))
  })

  let example_p1 =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

  day03.part1(example_p1)
  |> should.equal(161)

  let example_p2 =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
  day03.part2(example_p2)
  |> should.equal(48)
}
