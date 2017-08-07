from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship

engine = create_engine('sqlite:///:memory:', echo=True)
Session = sessionmaker(bind=engine)
session = Session()

Base = declarative_base()


class Related(Base):
    __tablename__ = 'related'
    parent = Column(Integer, ForeignKey("parent.id"))
    key1 = Column(Integer, primary_key=True, nullable=True)
    key2 = Column(Integer, primary_key=True, nullable=True)

    def __init__(self, key1, key2):
        self.key1, self.key2 = key1, key2


class Parent(Base):
    __tablename__ = 'parent'
    id = Column(Integer, primary_key=True)
    related = relationship(Related, collection_class=set)

Base.metadata.create_all(engine)

# First object
parent = Parent()
r1 = Related(3, None)
parent.related.add(r1)
session.add(parent)
session.commit()

parent.related.remove(r1)
session.commit()
