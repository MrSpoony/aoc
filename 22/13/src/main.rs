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
    let mut res = 0;
    for (i, pair) in pairs.iter().enumerate() {
        let part1 = parse_pair(pair[0].clone(), 1, pair[0].len() - 1);
        let part2 = parse_pair(pair[1].clone(), 1, pair[1].len() - 1);
        match compare_parts(&part1, &part2) {
            Ordering::Less => res += i + 1,
            _ => (),
        }
    }

    let mut parts = pairs.clone().into_iter().flatten().collect::<Vec<_>>();
    parts.push("[[2]]".chars().collect());
    parts.push("[[6]]".chars().collect());
    parts.sort_by(|a, b| {
        let p1 = parse_pair(a.clone(), 1, a.len() - 1);
        let p2 = parse_pair(b.clone(), 1, b.len() - 1);
        return compare_parts(&p1, &p2);
    });
    let idx1: usize = parts
        .iter()
        .position(|x| x == &"[[2]]".chars().collect::<Vec<_>>())
        .unwrap()
        + 1;
    let idx2: usize = parts
        .iter()
        .position(|x| x == &"[[6]]".chars().collect::<Vec<_>>())
        .unwrap()
        + 1;
    let res2 = idx1 * idx2;
    println!("{}", res);
    println!("{}", res2);
}

fn parse_pair(s: Vec<char>, start: usize, end: usize) -> Part {
    let mut root = Part::List(vec![]);
    let mut starts = vec![];
    for i in start..end {
        let c = s[i];
        if c == '[' {
            starts.push(i + 1);
        } else if c == ']' {
            if starts.len() == 1 {
                if let Part::List(root) = &mut root {
                    root.push(parse_pair(s.clone(), starts.pop().unwrap(), i));
                }
            } else {
                starts.pop();
            }
        } else if c == ',' {
            continue;
        } else {
            if starts.len() != 0 {
                continue;
            }
            let idx = s[i..].iter().position(|&c| c == ',' || c == ']').unwrap();
            let num = s[i..i + idx]
                .iter()
                .collect::<String>()
                .parse::<i32>()
                .unwrap();
            if let Part::List(root) = &mut root {
                root.push(Part::Num(num));
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
