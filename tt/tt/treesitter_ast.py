from __future__ import annotations
import tree_sitter_typescript as tstypescript
from tree_sitter import Language, Parser
from pathlib import Path

def print_tree(node, source_code, indent=0):
    """Print the AST node and its type."""
    # node.type is the name of the node (e.g., 'class_declaration')
    # node.text gives the actual code for that node
    text = source_code[node.start_byte:node.end_byte].decode('utf8').replace('\n', ' ')
    if len(text) > 40:
        text = text[:37] + "..."
    
    print("  " * indent + f"[{node.type}] {text}")
    for child in node.children:
        print_tree(child, source_code, indent + 1)

def main():
    # 1. Initialize the TS language
    TS_LANGUAGE = Language(tstypescript.language_typescript())
    
    # 2. Create a parser and set its language
    parser = Parser(TS_LANGUAGE)
    
    # 3. Path to the source file
    repo_root = Path(__file__).parent.parent.parent
    ts_source_path = (
        repo_root / "projects" / "ghostfolio" / "apps" / "api" / "src"
        / "app" / "portfolio" / "calculator" / "roai" / "portfolio-calculator.ts"
    )
    
    if not ts_source_path.exists():
        print(f"File not found: {ts_source_path}")
        return

    # 4. Read and parse the file
    source_code = ts_source_path.read_bytes()
    tree = parser.parse(source_code)
    
    # 5. Print a small portion of the tree to show it works
    print(f"Successfully parsed: {ts_source_path.name}")
    print("\nRoot node type:", tree.root_node.type)
    
    # Print the first few top-level nodes (imports, class, etc.)
    print("\nTop-level structure:")
    for child in tree.root_node.children:
        if child.type in ["class_declaration", "interface_declaration", "export_statement"]:
            # Only print meaningful top-level things to avoid noise
            print_tree(child, source_code)

if __name__ == "__main__":
    main()
