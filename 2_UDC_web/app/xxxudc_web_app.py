# Author: R.Lisovenko
# Date: 22.09.2026
# Description: Flask web application for the Universal Data Converter.

from flask import Flask

from db_con_UDC import get_connection
from utils.CONSTANT_config import (
    AUTHOR,
    SERVER,
    DATABASE,
)

app = Flask(__name__)


@app.route("/")
def index():
    """
    Main UDC web page.
    """

    return f"""
    <h1>Universal Data Converter</h1>

    <p>Author: {AUTHOR}</p>

    <p>Web application is running.</p>

    <p>
        <a href="/db-status">Check database connection</a>
    </p>
    """


@app.route("/db-status")
def db_status():
    """
    Check connection to the Converter_UDC database.
    """

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT DB_NAME()")
        database_name = cursor.fetchone()[0]

        cursor.close()
        connection.close()

        return f"""
        <h1>Database Status</h1>

        <p>Server: {SERVER}</p>
        <p>Database: {database_name}</p>
        <p>Status: Connected</p>

        <p>
            <a href="/">Back</a>
        </p>
        """

    except Exception as error:
        return f"""
        <h1>Database Status</h1>

        <p>Server: {SERVER}</p>
        <p>Database: {DATABASE}</p>
        <p>Status: Connection error</p>

        <pre>{error}</pre>

        <p>
            <a href="/">Back</a>
        </p>
        """, 500


if __name__ == "__main__":

    # 0.0.0.0 is required so Flask is reachable
    # from outside the Docker container.
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False,
    )
