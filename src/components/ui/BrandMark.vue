<template>
  <span class="mark">
    <svg viewBox="0 0 44 44" width="40" height="40" aria-hidden="true">
      <rect width="44" height="44" rx="11" fill="var(--ink)" />
      <path d="M9 21 16.5 11l5 6.5 3.5-4.5L35 21" fill="none" stroke="var(--paper)" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" />
      <path d="M8 29.5c4.5-2.6 9-2.6 14 0s9.5 2.6 14 0" fill="none" stroke="var(--signal)" stroke-width="2.6" stroke-linecap="round" />
    </svg>
    <span class="words">
      <span class="usi">USI</span>
      <span class="full">Università della<br />Svizzera italiana</span>
    </span>
  </span>
</template>

<style scoped>
.mark {
  display: inline-flex;
  align-items: center;
  gap: 0.7rem;
}
.words {
  display: flex;
  align-items: center;
  gap: 0.7rem;
}
.usi {
  font-family: var(--font-display);
  font-size: 1.55rem;
  font-weight: 500;
  letter-spacing: -0.03em;
  line-height: 1;
}
.full {
  display: none;
  padding-left: 0.7rem;
  border-left: 1px solid var(--line-strong);
  font-size: 0.72rem;
  line-height: 1.2;
  color: var(--ink-2);
}
@media (min-width: 1240px) {
  .full {
    display: block;
  }
}
</style>
