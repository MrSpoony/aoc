fn main() {
    let pairs = include_str!("../input.txt")
        .lines()
        .map(|line| line.split(","))
        .map(|pairs| {
            pairs
                .map(|pair| {
                    pair.split("-")
                        .map(|pair| pair.parse::<i32>().unwrap())
                        .collect::<Vec<_>>()
                })
                .collect::<Vec<_>>()
        });
    println!(
        "{}",
        pairs
            .clone()
            .map(
                |pairs| pairs[0][0] <= pairs[1][0] && pairs[0][1] >= pairs[1][1]
                    || pairs[1][0] <= pairs[0][0] && pairs[1][1] >= pairs[0][1]
            )
            .filter(|x| *x)
            .count()
    );
    println!(
        "{}",
        pairs
            .map(
                |pairs| pairs[0][1] >= pairs[1][0] && pairs[0][1] <= pairs[1][1]
                    || pairs[1][1] >= pairs[0][0] && pairs[1][1] <= pairs[0][1]
            )
            .filter(|x| *x)
            .count()
    );
}
