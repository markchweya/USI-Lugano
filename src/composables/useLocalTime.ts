import { onBeforeUnmount, onMounted, ref } from 'vue'

const fmt = new Intl.DateTimeFormat('en-GB', { hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Zurich' })

/** The current wall-clock time in Lugano, refreshed every 30 seconds. */
export function useLuganoTime() {
  const time = ref(fmt.format(new Date()))
  let id: number | undefined
  onMounted(() => {
    id = window.setInterval(() => (time.value = fmt.format(new Date())), 30_000)
  })
  onBeforeUnmount(() => window.clearInterval(id))
  return time
}
