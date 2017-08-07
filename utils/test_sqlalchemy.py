from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from neutron.db import models_v2

engine = create_engine(
    'mysql+pymysql://root:devstack@127.0.0.1/neutron?charset=utf8',
    echo=False)
connection = engine.connect()
result = connection.execute('select * from ports')
ports = [p for p in result]
connection.close()
session = sessionmaker()
session.configure(bind=engine)
s = session()
query = s.query(models_v2.Port)
