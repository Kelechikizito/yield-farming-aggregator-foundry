export default function() {
    return (
         <footer className="mt-16 pt-8 border-t border-border">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="flex space-x-6 mb-4 md:mb-0">
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                About
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                FAQ
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                Terms
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-accent transition-colors"
              >
                Privacy
              </a>
            </div>
            <a
                href="https://github.com/Kelechikizito"
                className="text-muted-foreground hover:text-accent transition-colors text-sm"
              >
                Made By Kelechi Kizito Ugwu
              </a>
          </div>
        </footer>
    )
}