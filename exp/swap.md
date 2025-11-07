## Can not open swap file, can not recovery 
may be permission issue, check swap file path by

```nvim
:echo &directory
```

then change the directory owner by

```sh
sudo chown -R user path-to-directory
```





