from __future__ import annotations

import logging
import logging.config

logger = logging.getLogger(__name__)


def main() -> None:
    _init_logging()


def _init_logging() -> None:
    logging.config.dictConfig(
        {
            "version": 1,
            "formatters": {
                "default": {
                    "format": "%(message)s",
                },
            },
            "handlers": {
                "default": {
                    "class": "logging.StreamHandler",
                    "formatter": "default",
                },
            },
            "root": {"level": "WARNING", "handlers": ["default"]},
            "loggers": {
                **{
                    pkg: {
                        "level": "DEBUG",
                        "handlers": ["default"],
                        "propagate": False,
                    }
                    for pkg in ("arena", "test", "__main__")
                }
            },
        }
    )


if __name__ == "__main__":
    main()
