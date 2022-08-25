<script>
	import Navbar from '../components/Navbar.svelte';

	import '../app.css';
</script>

<Navbar />

<div class="flex-grow self-center mt-16 mb-16 px-4">
	<slot />
</div>
