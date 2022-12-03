fn main() {
    let converted_lines = include_str!("../input.txt")
        .lines()
        .map(|line| {
            line.split(" ")
                .map(|c| c.chars().collect::<Vec<char>>()[0])
                .collect::<Vec<char>>()
        })
        .map(|line| {
            line.iter()
                .map(|c| {
                    if c >= &'A' && c <= &'C' {
                        *c as u8 - 'A' as u8
                    } else {
                        *c as u8 - 'X' as u8
                    }
                })
                .map(Into::<i32>::into)
                .collect::<Vec<i32>>()
        })
        .collect::<Vec<Vec<i32>>>();
    println!(
        "{}",
        converted_lines
            .iter()
            .map(|line| {
                return (match (line[1] - line[0] + 3) % 3 {
                    0 => 3,
                    1 => 6,
                    2 => 0,
                    _ => 0,
                }) + line[1]
                    + 1;
            })
            .sum::<i32>()
    );
    println!(
        "{}",
        converted_lines
            .iter()
            .map(|line| {
                return (match line[1] {
                    0 => 0 + ((line[0]+2)%3),
                    1 => 3 + line[0],
                    2 => 6 + ((line[0]+1)%3),
                    _ => 0,
                })
                    + 1;
            })
            .sum::<i32>()
    )
}
