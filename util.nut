class Util
{
	MAXINT = -1 ^ (1 << _intsize_ * 8 - 1);
	MININT = 1 + (-1 ^ (1 << _intsize_ * 8 - 1));

	function Find(arr, elem)
	{
		local n = arr.len();
		for (local i = 0; i < n; i++)
			if (arr[i] == elem)
				return i;
		return null;
	}

	function Remove(arr, elem)
	{
		local n = arr.len();
		for (local i = 0; i < n; i++)
			if (arr[i] == elem)
			{
				arr.remove(i);
				return;
			}
	}

	function Min(...)
	{
		local m = Util.MAXINT;
		for (local i = 0; i < vargc; i++)
		{
			local v = vargv[i];
			if (v < m)
				m = v;
		}
		return m;
	}

	function Max(...)
	{
		local m = Util.MININT;
		for (local i = 0; i < vargc; i++)
		{
			local v = vargv[i];
			if (m < v)
				m = v;
		}
		return m;
	}

	function Compare(a, b)
	{
		if (a < b)
			return -1;
		if (a > b)
			return 1;
		return 0;
	}

	function In(es, v)
	{
		foreach (e in es)
			if (e == v)
				return true;
		return false;
	}
}
