module helpers.searching;

T find(T)(T[] source, bool delegate(T) predecate)
{
    foreach (item; source)
    {
        if (predecate(item))
        {
            return item;
        }
    }

    throw new Exception("No such element");
}

T indexOrInit(T)(T[] source, size_t index)
{
    const(int) length = cast(int) source.length;
    if (length - 1 < index)
    {
        return T.init;
    }

    return source[index];
}