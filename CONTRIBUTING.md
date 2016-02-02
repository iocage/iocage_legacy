# Contribution guidelines

Following the contribution guidelines saves everyone time, requires less back
and forth during the review process, and helps to ensures a consistent codebase.
*Note: historical code doesn't follow all of these guidelines*

####A few general rules first:
- Open any pull request against the `develop` branch
- Use double quotes for everything that isn't a `FOR` loop.
- Keep code to 80 characters or less, otherwise split them with a `\`. Only indent 4 spaces the first time you split the line:
```
long command \
    next line \
    next line \
```
- Comment your code
- Do not use tabs, use spaces instead. 4 spaces to start, and 4 more for each additional nesting that occurs:
```
if [ "$(command | test)" ] ; then
    if [ "$(new command | different test)" ] ; then
        for _var in ${_var_list} ; do
            stuff
        done

        if [ "$(last command | last test)" ] ; then
            echo "Note same indentation as the previous for loop as this is " \
                "not another nested level"
        fi
    fi
fi
```
- Update ioc-help (**_not iocage.8/iocage.8.txt_**) if new/changed docs are needed for your change. Requires `txt2man`.
<p>(`iocage help | txt2man -t iocage -s 8 -v "FreeBSD System Manager's Manual" > iocage.8`, followed by `iocage help > iocage.8.txt`)</p>
- Pull request description should clearly show what the change is including output if relevant.
- Squash commits before opening a pull request.
- Test and then test again! Make sure it works with the latest changes in `develop`.
- Use a line break between any statements/loops.
<br>

####IF statements
-----
- Use `-a` for AND operators and `-o` for OR operators.
Use brackets and ensure that they follow this style:
```
if [ "${VAR}" = "string" ] ; then
    stuff
fi
```
<br>

####FOR loops
-----
Make sure they follow this style:
```
for _var in ${_var_list} ; do
    stuff
done
```

<br>

####WHILE loops
-----
Make sure they follow this style:
```
while [ "${?}" -gt 0 ] ; do
    stuff
done
```

<br>

####CASE statements
----
Make sure they follow this style:
```
case "${_var}" in
    string) stuff
        ;;
    another) more stuff
        ;;
esac
```

<br>

####Variables and functions
-----
- Format functions as `__function_name ()`
- Format local variables as `_var` and global variables as `var`
- Use local variables for each function, avoid using global ones.
- Use braces on all variables "${_var}"
- Make sure you declare all variables at the top: `local _var1 _var2`
- Use a line break between declaration and actual assignment:
```
local _var1 _var2

_var1="foo"
_var2="bar"
```

<br>

####Documentation for Read The Docs
-----
If you wish to update some of our [documentation] (http://iocage.readthedocs.org), you only need to submit a PR for the files you change in iocage/doc/source. They will automatically be updated when the changes are merged into our `Master` branch.
