<script>
	import NavItem from './NavItem.svelte';
</script>

<header
	class="container bg-paper min-w-full  mx-auto sm:flex sm:justify-between sm:max-w-3xl xl:max-w-5xl"
>
	<div class="flex items-center justify-between px-4 py-2">
		<div>
			<a href="/">
				<img class="h-8 font-display" src="/images/logos/icon-logo.svg" alt="StoryStains" />
			</a>
		</div>
	</div>
	<div class="px-1 py-3 pb-3 shadow-lg font-normal rounded sm:flex sm:shadow-none items-center">
		<NavItem name="Home" href="/" />
		<NavItem name="About" href="/about" />
	</div>
</header>
