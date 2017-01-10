{application, 'erlapp', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['action_handler','arena','erlapp_app','erlapp_sup','gate','guestbook','hello_handler','resolution','talk','temple']},
	{registered, [erlapp_sup]},
	{applications, [kernel,stdlib,cowboy]},
	{mod, {erlapp_app, []}},
	{env, []}
]}.