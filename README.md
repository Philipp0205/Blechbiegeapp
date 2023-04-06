# Blechbiege App

Work in progress... 


# Hive Database 

## Generate Adapter
1. To generate a TypeAdapter for a class, annotate it with @HiveType and provide a typeId (between 0 and 223)
2. Annotate all fields which should be stored with @HiveField
3. Run flutter build task `flutter packages pub run build_runner build`
4. Register the generated adapter

[Source](https://docs.hivedb.dev/#/custom-objects/generate_adapter)

## Save git credentials locally 
To store your credentials in cache and avoid logging in every time you perform a git action, follow these steps:

1. Navigate to your local repository folder.
2. In the current folder's terminal: git config --global --replace-all credential.helper cache
3. Perform git push or git pull.
4. Login with username and access token (access token is your password). The token can be setup in GitHub and have access to repo, workflow, write:packages and delete:packages.
5. Repeat git push or any git action and you'll find that it doesn't ask for login credentials from now on.

[Source](https://stackoverflow.com/a/69559900/7127837)

## A note about states 
This projects uses Bloc for state management.  
To emit a state you will often see things like: 

```dart
emit(state.copyWith(lines: []));
emit(state.copyWith(lines: lines));
```

Only emitting a changed list is not enough because the underlying object does not change. 
Because dart offers no deep copy of objects an emtpy state is emitted before the new state.
See for more details: https://github.com/felangel/bloc/issues/1703 for more details. 






