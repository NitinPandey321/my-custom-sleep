import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static values = {
    scores: Array,
    sleep: Array,
    heart: Array
  }

  connect() {
    this.renderCharts()
  }

  scoresValueChanged() { this.renderCharts() }
  sleepValueChanged() { this.renderCharts() }
  heartValueChanged() { this.renderCharts() }

  renderCharts() {
    if (this.hasScoresValue && this.hasSleepValue) {
      this.renderSleepChart()
    }
    if (this.hasHeartValue) {
      this.renderHeartRateChart()
    }
  }

  disconnect() {
    if (this.sleepChart) this.sleepChart.destroy()
    if (this.heartChart) this.heartChart.destroy()
  }

  renderSleepChart() {
    const ctx = document.getElementById("sleepScoreChart")?.getContext("2d")
    if (!ctx) return

    if (this.sleepChart) this.sleepChart.destroy()

    const labels = this.scoresValue.map(d => d.day)
    const scores = this.scoresValue.map(d => d.score)
    const durations = this.sleepValue.map(d => Math.round(d.total_sleep_duration / 3600 * 10) / 10)

    this.sleepChart = new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            label: "Sleep Score",
            data: scores,
            borderColor: "#4CAF50",
            backgroundColor: "rgba(76, 175, 80, 0.1)",
            tension: 0.3,
            pointRadius: 3,
            fill: true
          },
          {
            label: "Total Sleep (hrs)",
            data: durations,
            borderColor: "#2196F3",
            backgroundColor: "rgba(33, 150, 243, 0.1)",
            tension: 0.3,
            pointRadius: 3,
            fill: true,
            yAxisID: "y1"
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { beginAtZero: true, title: { display: true, text: "Sleep Score" } },
          y1: {
            beginAtZero: true,
            position: "right",
            grid: { drawOnChartArea: false },
            title: { display: true, text: "Sleep Hours" }
          }
        }
      }
    })
  }

  renderHeartRateChart() {
    const ctx = document.getElementById("heartRateChart")?.getContext("2d")
    if (!ctx || this.heartValue.length === 0) return

    if (this.heartChart) this.heartChart.destroy()

    const labels = this.heartValue.map(d => new Date(d.timestamp).toLocaleTimeString())
    const bpm = this.heartValue.map(d => d.bpm)

    this.heartChart = new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            label: "Heart Rate (bpm)",
            data: bpm,
            borderColor: "#FF5722",
            backgroundColor: "rgba(255, 87, 34, 0.1)",
            tension: 0.3,
            pointRadius: 3,
            fill: true
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { beginAtZero: true, title: { display: true, text: "Heart Rate (bpm)" } }
        }
      }
    })
  }
}
