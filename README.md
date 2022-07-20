# Blechbiege App

Work in progress... 


# Hive Database 

## Generate Adapter
1. To generate a TypeAdapter for a class, annotate it with @HiveType and provide a typeId (between 0 and 223)
2. Annotate all fields which should be stored with @HiveField
3. Run build task flutter packages pub run build_runner build
4. Register the generated adapter

https://docs.hivedb.dev/#/custom-objects/generate_adapter
