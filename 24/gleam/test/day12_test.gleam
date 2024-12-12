import day12
import gleeunit/should

const example = "
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"

pub fn part1_test() {
  day12.part1(example) |> should.equal(1930)
}

pub fn part2_test() {
  day12.part2(example) |> should.equal(1206)

  day12.part2(
    "
EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
",
  )
  |> should.equal(236)

  day12.part2(
    "
AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
",
  )
  |> should.equal(368)
}
