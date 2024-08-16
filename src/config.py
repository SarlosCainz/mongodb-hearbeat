from pydantic_settings import BaseSettings
from pydantic import AnyHttpUrl

class Settings(BaseSettings):
    db_hosts: list
    db_replica_set: str = ""
    db_user: str = "root"
    db_password: str
    debug: bool = True
    heartbeat_url: AnyHttpUrl
    retry_count: int = 5
    interval_min: int = 5


settings = Settings()
