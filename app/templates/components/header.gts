import { ThemeToggle } from 'nvp.ui';
import { ExternalLink } from 'ember-primitives/components/external-link';

import { Arrow } from './icons/fa/external-link';

export const Header = <template>
  <header>
    <div class="left">
      <a href="/" aria-label="Home" title="Home">🏠</a>
      <ExternalLink
        class="github"
        href="https://github.com/NullVoxPopuli/turborepo-summary-analyzer"
      >
        <img alt="" src="/images/github-logo.png" />
        GitHub
        <Arrow />
      </ExternalLink>
      <a href="/import">Analyze Summary File</a>
      <a href="/compare">Compare Summaries</a>
    </div>

    <div>
      <ThemeToggle />
    </div>
  </header>
  <style>
    header {
      display: flex;
      justify-content: space-between;
      background: rgb(40 40 40);
      height: 36px;
      padding: 0.5rem;

      h1 {
        margin: 0;
        color: white;
      }

      .left {
        display: flex;
        align-items: center;
        gap: 0.125rem;
        a {
          color: var(--github-font);
          border-radius: 0.25rem;
          padding: 0.25rem 1rem;

          &:hover {
            text-decoration: underline;
          }
        }
      }
    }

    a.github {
      align-items: center;
      color: var(--github-font);
      padding: 0.25rem 1rem;
      display: grid;
      grid-auto-flow: column;
      gap: 0.5rem;
    }

    a.github:hover {
      text-decoration: underline;
    }

    a.github img {
      mix-blend-mode: difference;
      max-height: 1.2rem;
    }
  </style>
</template>;
