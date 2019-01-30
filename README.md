# Manudped RSS Trans

## How to build

From root directory, run:
```
$ docker run -v $PWD/app:/volume --rm -it clux/muslrust cargo build --release
```

## How to deploy

Run:

```
./deploy.sh
```

To deploy the app together with infrastructure changes.
