use std::cmp::Ordering;

#[derive(Debug, Clone)]
enum Part {
    List(Vec<Part>),
    Num(i32),
}

fn main() {
    let pairs: Vec<Vec<Vec<char>>> = include_str!("../input.txt")
        .split("\n\n")
        .map(|x| x.lines().map(|x| x.chars().collect()).collect())
        .collect();

    let mut parts = pairs.clone().into_iter().flatten().collect::<Vec<_>>();
    let additionals: Vec<Vec<char>> = vec!["[[2]]".chars().collect(), "[[6]]".chars().collect()];
    parts.extend(additionals.clone());
    parts.sort_by(|a, b| compare_parts(&parse_pair(a.clone()), &parse_pair(b.clone())));
    println!(
        "{}",
        pairs
            .iter()
            .enumerate()
            .filter_map(|(i, pair)| {
                let x: Vec<_> = pair.iter().map(|x| parse_pair(x.to_vec())).collect();
                if let Ordering::Less = compare_parts(&x[0], &x[1]) {
                    Some(i + 1)
                } else {
                    None
                }
            })
            .sum::<usize>()
    );
    println!(
        "{}",
        additionals
            .into_iter()
            .map(|a| parts.iter().position(|x| x == &a).unwrap() + 1)
            .product::<usize>()
    );
}

fn parse_pair(s: Vec<char>) -> Part {
    return parse_pair_start_end(s.clone(), 1, s.len() - 1);
}

fn parse_pair_start_end(s: Vec<char>, start: usize, end: usize) -> Part {
    let mut root = Part::List(vec![]);
    let mut starts = vec![];
    for i in start..end {
        let c = s[i];
        if c == '[' {
            starts.push(i + 1);
        } else if c == ']' {
            if starts.len() != 1 {
                starts.pop();
                continue;
            } else if let Part::List(root) = &mut root {
                root.push(parse_pair_start_end(s.clone(), starts.pop().unwrap(), i));
            }
        } else if c == ',' {
            continue;
        } else {
            if starts.len() != 0 {
                continue;
            } else if let Part::List(root) = &mut root {
                root.push(Part::Num(
                    s[i..i + s[i..].iter().position(|&c| c == ',' || c == ']').unwrap()]
                        .iter()
                        .collect::<String>()
                        .parse::<i32>()
                        .unwrap(),
                ));
            }
        }
    }
    return root;
}

fn compare_parts(p1: &Part, p2: &Part) -> Ordering {
    match (p1, p2) {
        (Part::Num(n1), Part::Num(n2)) => n1.cmp(n2),
        (Part::List(l1), Part::List(l2)) => {
            for i in 0..l1.len().min(l2.len()) {
                match compare_parts(&l1[i].clone(), &l2[i].clone()) {
                    Ordering::Equal => continue,
                    Ordering::Less => return Ordering::Less,
                    Ordering::Greater => return Ordering::Greater,
                }
            }
            return l1.len().cmp(&l2.len());
        }
        (Part::Num(_), Part::List(_)) => {
            return compare_parts(&Part::List(vec![p1.clone()]), &p2.clone());
        }
        (Part::List(_), Part::Num(_)) => {
            return compare_parts(&p1.clone(), &Part::List(vec![p2.clone()]));
        }
    }
}
