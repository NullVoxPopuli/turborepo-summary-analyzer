import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import type { SummaryTask } from 'turborepo-summary-analyzer/types';
import * as Plot from '@observablehq/plot';
import * as d3 from 'd3';
import { modifier } from 'ember-modifier';
import { taskDuration } from 'turborepo-summary-analyzer/utils';
import { colorScheme } from 'ember-primitives/color-scheme';

function isDark() {
  return colorScheme.current === 'dark';
}

/**
 * https://observablehq.com/@observablehq/build-your-own-gantt-chart
 */
export class Timeline extends Component<{
  Args: {
    tasks: SummaryTask[];
  };
}> {
  @cached
  get byId() {
    return d3.index(this.args.tasks, (d) => d.taskId);
  }

  @cached
  get groups() {
    return [...new Set([...this.args.tasks.map((x) => x.package)])];
  }

  @cached
  get byDate() {
    return this.args.tasks.sort((a, b) =>
      d3.ascending(a.execution.startTime, b.execution.startTime)
    );
  }

  /**
   * Observable Plots are not reactive...
   * so they say to replace the entire thing when there are updates...
   */
  renderInto(element: HTMLElement) {
    const box = element.getBoundingClientRect();

    const colorSpace = isDark()
      ? d3.interpolateHcl('#ff0000', '#ff00ff')
      : d3.interpolateHclLong('magenta', 'orange');

    const getColor = (group: string) => {
      const idx = this.groups.indexOf(group);
      const select = this.groups.length / (idx + 1);
      return colorSpace(select);
    };

    const plot = Plot.plot({
      height: box.height,
      width: box.width,
      color: {
        // type: 'linear',
        range: this.groups.map((group) => getColor(group)),
        interpolate: 'hcl',
        // domain: this.groups,
        legend: true,
      },
      x: {
        grid: true,
        type: 'utc',
      },
      y: {
        grid: false,
        // tickFormat: (t) => this.byId.get(t)?.taskId,
        tickFormat: null,
        axis: 'left',
        label: null,
      },
      // color: { domain: this.byGroup, range: this.colors, legend: false },
      marks: [
        Plot.barX(this.args.tasks, {
          fill: 'package',
          stroke: 'package',
          // fill: (d) => getColor(d.package),
          // stroke: (d) => getColor(d.package),
          fillOpacity: 0.6,
          x1: (d: SummaryTask) => d.execution.startTime,
          x2: (d: SummaryTask) => d.execution.endTime,
          y: (d: SummaryTask) => d.taskId,
          title: (d: SummaryTask) => {
            let title = `${d.package} >> ${d.task}\n ${taskDuration(d)}\n`;

            if (d.dependencies.length) {
              title += '\n';
              title += `Dependencies: \n${d.dependencies.join('\n')}`;
            }

            return title;
          },
        }),
        Plot.text(this.args.tasks, {
          x: (d: SummaryTask) => d.execution.startTime,
          y: (d: SummaryTask) => d.taskId,
          text: (d: SummaryTask) => taskDuration(d),
          textAnchor: 'start',
          dy: 0,
          dx: 6,
          fontSize: 12,
          stroke: isDark() ? 'black' : 'white',
          strokeWidth: 1,
          fill: isDark() ? 'white' : 'dimgray',
          fontWeight: 500,
        }),
      ],
    });

    element.innerHTML = '';
    element.append(plot);
  }

  #frame: number = -1;
  handleResize = (entries: ResizeObserverEntry[]) => {
    cancelAnimationFrame(this.#frame);
    this.#frame = requestAnimationFrame(() => {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      const target = entries.find((x) => x.target).target;
      this.renderInto(target as HTMLElement);
    });
  };
  resizeObserver = new ResizeObserver(this.handleResize);

  chart = modifier<{ Element: HTMLElement }>((element) => {
    this.renderInto(element);
    this.resizeObserver.observe(element);
  });

  <template>
    <div style="width: 100%; height: 75dvh;" {{this.chart}}></div>
  </template>
}
