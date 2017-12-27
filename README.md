# upm-proxy-service

[Docker Hub](https://hub.docker.com/r/bengreenier/upm-proxy-service/)

> Note: this is completely unoffical, and Unity will likely release their own version in the future.

A proxy upm service, to allow users to mix in private packages. Basically this just
wraps [verdaccio](https://github.com/verdaccio/verdaccio) with the correct configuration
to be a proxy for the new unity package manager service.

That way, we can __use custom packages__.

## License

MIT