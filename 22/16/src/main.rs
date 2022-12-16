use std::collections::HashMap;

fn main() {
    let input = include_str!("../input.txt");

    let mut valves = Vec::<(String, i32, Vec<String>)>::new();
    for line in input.trim().split('\n') {
        let new = line
            .replace("Valve ", "")
            .replace(" has flow rate=", ", ")
            .replace("tunnels", "tunnel")
            .replace("leads", "lead")
            .replace("valves", "valve")
            .replace("; tunnel lead to valve ", ", ");
        let x: Vec<_> = new.split(", ").collect();
        let (valve, flow, tunnels) = (
            String::from(x[0]),
            x[1].parse::<i32>().unwrap() as i32,
            x[2..].iter().map(|s| String::from(*s)).collect::<Vec<_>>(),
        );
        valves.push((valve, flow, tunnels));
    }

    valves.sort_by(|a, b| b.1.cmp(&a.1));
    let map = valves
        .iter()
        .enumerate()
        .map(|(i, v)| (v.0.clone(), i))
        .collect::<HashMap<_, _>>();
    let m = valves.iter().filter(|v| v.1 > 0).count();
    let n = valves.len();
    let mut adj = vec![vec![0; 0]; n];
    let mut flows = vec![0; n];
    for v in valves.iter() {
        let i = map[&v.0];
        flows[i] = v.1;
        for w in v.2.iter() {
            adj[i].push(map[w]);
        }
    }
    let start = map["AA"];

    let m_shift = 1 << m;
    let mut dp = vec![vec![vec![0; m_shift]; n]; 30];
    for t in 1..30 {
        for i in 0..n {
            let curr = 1 << i;
            for other in 0..m_shift {
                if curr & other != 0 && t >= 2 {
                    dp[t][i][other] =
                        dp[t][i][other].max(dp[t - 1][i][other - curr] + flows[i] * t as i32);
                }
                for &j in adj[i].iter() {
                    dp[t][i][other] = dp[t][i][other].max(dp[t - 1][j][other]);
                }
            }
        }
    }

    println!("{}", dp[29][start][m_shift - 1]);

    let mut best = 0;
    for x in 0..m_shift / 2 {
        let y = m_shift - 1 - x;
        best = best.max(dp[25][start][x] + dp[25][start][y]);
    }
    println!("{}", best);
}
