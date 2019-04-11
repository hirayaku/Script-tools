# Jupyter Notebook Server

For a complete tutorial, refer to [doc](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html).

## Generate configuration file

A config file should be generated by the host

```bash
jupyter notebook --generate-config
```
The config in `.py` format will be generated in `$HOME/.jupyter`

## Modify the configuration

Modify the following entries in the generated file:

```python
c.NotebookApp.allow_origin = '*'    # allow any origin to access the notebook
c.NotebookApp.ip = '0.0.0.0'        # listen on any incoming ports
c.NotebookApp.certfile = ''
c.NotebookApp.keyfile = ''          # authentication file required by HTTPS
c.NotebookApp.open_browser = False  # do not open browser in the server
c.NotebookApp.password = ''         # hashed password to access the notebook
c.NotebookApp.port = 8888 
```

The authentication files could be acquired by
- running `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.pem` on the host to create a certificate w/o SAN
- following the step on [ssl certificates with SAN](https://gist.github.com/croxton/ebfb5f3ac143cd86542788f972434c96) to create a certificate w/ SAN
- applying for certificates issued by [Let's Encrypt](https://letsencrypt.org)

The hashed password is generated by `password()` from `notebook.auth` in python.

Then, in the local machine, open the browser and access the server by 'ip:port', using https protocal.

The browser probably doesn't trust the personal certificate you generated on the host. To trust it, on macOS, download .pem file and add it into the trusted certificates using Keychain app.

At last, log in the notebook.