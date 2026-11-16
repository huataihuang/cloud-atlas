try:
    with open("new_file.txt", "x", encoding="utf-8") as f:
        f.write("Created safely!\n")
except FileExistsError:
    print("The file already exists.")
