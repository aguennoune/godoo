import typer

godoo = typer.Typer()

@godoo.command()
def hello(name: str):
    typer.echo(f"Hello, {name}!")

if __name__ == "__main__":
    godoo()