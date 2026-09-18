# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Common UDC import dispatcher. Selects an import file and starts the corresponding importer.

from utils.CONSTANT_config import IMPORT_DIR
from utils.import_CSV import import_from_csv


def import_data():
    """
    Display available import files and import the selected file.

    Current implementation:
    CSV import only.

    Additional import formats will be added later.
    """

    # Find CSV files in the import directory
    files = sorted(IMPORT_DIR.glob("*.csv"))

    if not files:
        print(f"No CSV files found in: {IMPORT_DIR}")
        return

    print("\nAvailable CSV files:\n")

    for index, file_path in enumerate(files, start=1):
        print(f"[{index}] {file_path.name}")

    print()

    selection = input(
        f"Select file [1-{len(files)}]: "
    ).strip()

    if not selection.isdigit():
        raise ValueError("File number must be numeric.")

    file_number = int(selection)

    if file_number < 1 or file_number > len(files):
        raise ValueError("Selected file number is out of range.")

    selected_file = files[file_number - 1]

    print(f"\nSelected file: {selected_file.name}")

    import_from_csv(selected_file.name)

#------------------------------------------------------
if __name__ == "__main__":
    try:
        import_data()

    except Exception as error:
        print(f"Import failed: {error}")
        raise