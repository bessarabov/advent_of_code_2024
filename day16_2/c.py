import sys
from collections import deque

def parse_input(filename):
    with open(filename, 'r') as file:
        grid = [list(line.strip()) for line in file.readlines()]
    start, end = None, None
    for r, row in enumerate(grid):
        for c, cell in enumerate(row):
            if cell == 'S':
                start = (r, c)
            elif cell == 'E':
                end = (r, c)
    return grid, start, end

def get_neighbors(grid, r, c):
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]  # Up, Down, Left, Right
    neighbors = []
    for dr, dc in directions:
        nr, nc = r + dr, c + dc
        if 0 <= nr < len(grid) and 0 <= nc < len(grid[0]) and grid[nr][nc] != '#':
            neighbors.append((nr, nc))
    return neighbors

def bfs_find_best_paths(grid, start, end):
    queue = deque([(start, 0, 0)])  # (position, steps, turns)
    best_scores = {}
    paths = {}
    best_path_tiles = set()

    while queue:
        (r, c), steps, turns = queue.popleft()
        score = steps + turns * 1000
        if (r, c) in best_scores and score > best_scores[(r, c)]:
            continue
        best_scores[(r, c)] = score
        paths[(r, c)] = (steps, turns)

        if (r, c) == end:
            continue

        for nr, nc in get_neighbors(grid, r, c):
            queue.append(((nr, nc), steps + 1, turns))

    # Backtrack to find all best paths
    stack = [end]
    while stack:
        curr = stack.pop()
        if curr in best_path_tiles:
            continue
        best_path_tiles.add(curr)
        if curr == start:
            continue
        for nr, nc in get_neighbors(grid, *curr):
            if (nr, nc) in paths and best_scores[(nr, nc)] + 1 == best_scores[curr]:
                stack.append((nr, nc))

    return best_path_tiles

def mark_best_paths(grid, best_path_tiles):
    result = [row[:] for row in grid]
    for r, row in enumerate(grid):
        for c, cell in enumerate(row):
            if (r, c) in best_path_tiles and cell not in ('S', 'E'):
                result[r][c] = 'O'
    return result

def count_best_path_tiles(best_path_tiles):
    return len(best_path_tiles)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 a.py input")
        sys.exit(1)

    input_file = sys.argv[1]
    grid, start, end = parse_input(input_file)
    best_path_tiles = bfs_find_best_paths(grid, start, end)
    marked_grid = mark_best_paths(grid, best_path_tiles)

    for row in marked_grid:
        print("".join(row))

    print("\nNumber of tiles on the best paths:", count_best_path_tiles(best_path_tiles))

if __name__ == "__main__":
    main()

