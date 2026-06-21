DB_CONFIG = {
    'host':     'localhost',
    'port':     3306,
    'user':     'root',
    'password': 'root',  # change this
    'database': 'pharma_sc'
}

def get_engine():
    from sqlalchemy import create_engine
    cfg = DB_CONFIG
    url = f"mysql+pymysql://{cfg['user']}:{cfg['password']}@{cfg['host']}:{cfg['port']}/{cfg['database']}"
    return create_engine(url)

def get_connection():
    import mysql.connector
    return mysql.connector.connect(**DB_CONFIG)