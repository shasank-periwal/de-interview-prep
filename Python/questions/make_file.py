import os
from openpyxl import load_workbook
from openpyxl.utils.exceptions import InvalidFileException

def extract_to_sql(excel_file, column, start_row, end_row, output_dir):
    """
    Extracts content from a specific column and row range in an Excel file and creates .sql files.

    Args:
        excel_file (str): Path to the Excel file.
        column (str): Column letter to extract data from.
        start_row (int): Starting row number.
        end_row (int): Ending row number.
        output_dir (str): Directory to save the .sql files.
    """
    # Load the workbook and the active sheet
    try:
        # Load the workbook with data_only to handle formulas and skip invalid data
        wb = load_workbook(excel_file, data_only=True)
    except InvalidFileException as e:
        print(f"Error loading file: {e}")
        return
    sheet = wb.active

    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    for row in range(start_row, end_row + 1):
        cell_value = sheet[f"{column}{row}"].value
        if cell_value:  # Skip empty cells
            # Create a SQL file for each row
            sql_file_name = os.path.join(output_dir, f"row_{row}.sql")
            with open(sql_file_name, "w", encoding="utf-8") as sql_file:
                sql_file.write(cell_value)
            print(f"Created: {sql_file_name}")
        else:
            print(f"Row {row} in column {column} is empty, skipping.")

# Example usage
if __name__ == "__main__":
    excel_file_path = "/home/shasankperiwal/Downloads/NCB_DP_Log bug & Follow up action.xlsx"  # Update with your Excel file path
    output_directory = "/home/shasankperiwal/Downloads/sqlFiles/"  # Directory to store the .sql files
    column_to_read = "H"  # Column letter to read (e.g., "A")
    start_row_number = 1  # Starting row number
    end_row_number = 150  # Ending row number

    extract_to_sql(excel_file_path, column_to_read, start_row_number, end_row_number, output_directory)
