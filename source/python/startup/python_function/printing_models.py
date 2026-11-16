def print_models(
    unprinted_designs: list,
    completed_models: list,
):
    """
    模拟打印每个设计，直到没有未打印的设计为止
    打印每个设计后，都将其移到列表 completed_models 中
    """
    while unprinted_designs:
        current_design = unprinted_designs.pop()
        print(f"Printing model: {current_design}")
        completed_models.append(current_design)


def show_completed_models(completed_models: list):
    """显示打印好的所有模型"""
    print()  # 空行打印无需传入"" (Ruff规则)
    print("The following models have been printed:")
    for completed_model in completed_models:
        print(completed_model)


if __name__ == "__main__":
    unprinted_designs = ["phone case", "robot pendant", "dodecahedron"]
    completed_models = []
    print_models(unprinted_designs, completed_models)
    show_completed_models(completed_models)

