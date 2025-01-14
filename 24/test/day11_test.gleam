import day11
import gleeunit/should

const example = "125 17"

pub fn part1_test() {
  day11.part1(example) |> should.equal(55_312)
}

pub fn part2_test() {
  day11.part2(example) |> should.equal(65_601_038_650_482)
}
