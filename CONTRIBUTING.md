# Contribution guidelines

Following the contribution guidelines saves everyone time, requires less back
and forth during the review process, and helps to ensures a consistent codebase.
*Note: historical code doesn't follow all of these guidelines*

####A few general rules first:
- Open any pull request against the `develop` branch
- Use double quotes for everything that isn't a `FOR` loop.
- Keep code to 80 characters or less, otherwise split them with a `\`
- Comment your code
- Use 4 spaces instead of tabs
- Update ioc-help if needed for your change  -- requires `txt2man`
<p>(`iocage help | txt2man -t iocage -s 8 -v "FreeBSD System Manager's Manual" > iocage.8`, followed by `iocage help > iocage.8.txt`)</p>
- Pull request description should clearly show what the change is including output if relevant.
- Squash commits before opening a pull request.
- Test and then test again! Make sure it works with the latest changes in `develop`.

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

<br>

####Documentation for Read The Docs
-----
If you wish to update some of our [documentation] (http://iocage.readthedocs.org), you only need to submit a PR for the files you change in iocage/doc/source. They will automatically be updated when the changes are merged into our `Master` branch.
