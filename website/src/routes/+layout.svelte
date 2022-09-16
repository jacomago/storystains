<script>
	import Navbar from '../components/Navbar.svelte';

	import '../app.scss';
	import Footer from '../components/Footer.svelte';
</script>

<navbar />

<div class="flex-grow self-center mt-16 mb-16 px-4">
	<slot />
</div>

<footer />
