import day01
import day02
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
