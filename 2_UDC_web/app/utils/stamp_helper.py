# Author: R.Lisovenko@outlook.com
# Date: 18.09.2026
# Description: Common metadata stamp for UDC export files.

from datetime import datetime
from utils.CONSTANT_config import AUTHOR, TYPE_OBJ

def get_export_stamp():
    """
    Return common metadata for generated UDC export files.
    """

    return (
        f"{TYPE_OBJ} Export | "
        f"Author LiR: {AUTHOR} | "
        f"Date: {datetime.now().strftime('%d.%m.%Y %H:%M:%S')}"
    )