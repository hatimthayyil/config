build:
    nh os build . && nh home build .

switch:
    nh os switch . && nh home switch .

clean:
    nh clean all

os:
    nh os switch .

home:
    nh home switch .
