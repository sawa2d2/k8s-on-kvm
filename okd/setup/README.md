## Enable all default sources of OperatorHub
```
oc patch operatorhub cluster -p '{"spec": {"disableAllDefaultSources": false}}' --type=merge
```

## Create admin user
Create htpassword provider CR
```
oc apply -f htpasswd_provider.yaml
```

Add `admin user`
```
htpasswd -c -B -b users.htpasswd admin <PASSWORD>
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
oc adm policy add-cluster-role-to-user cluster-admin admin
```

